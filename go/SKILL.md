---
name: go
description: Guide for how to develop Go apps and modules/libraries.
license: MIT
---

# Go

This is a guide for how to develop applications and modules/libraries in Go.

Some of it is only applicable for applications, not modules used as libraries in other projects, such as database access and running a server.

## Application structure

Generally, I build web applications and libraries/modules.

These are the packages typically present in applications (some may be missing, which typically means I don't need them in the project).

- `main`: contains the main entry point of the application (in directory `cmd/app`)
- `model`: contains the domain model used throughout the other packages
- `sql`/`sqlite`/`postgres`: contains SQL database-related logic as well as database migrations (under subdirectory `migrations/`) and test fixtures (under subdirectory `testdata/fixtures/`). The database used is either SQLite or PostgreSQL.
- `sqltest`/`sqlitetest`/`postgrestest`: package used in testing, for setting up and tearing down test databases
- `s3`: logic for interacting with Amazon S3 or compatible object stores
- `s3test`: package used in testing, for setting up and tearing down test S3 buckets
- `llm`: clients for interacting with large language models (LLMs) and foundation models
- `llmtest`: package used in testing, for setting up LLM clients for testing
- `http`: HTTP handlers for the application
- `html`: HTML templates for the application, written with the gomponents library (see https://www.gomponents.com/llms.txt for how to use that if you need to)

## Code style

### Dependency injection

I make heavy use of dependency injection between components. This is typically done with private interfaces on the receiving side. Note the use of `userGetter` in this example:

```go user.go
package http

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"maragu.dev/httph"

	"model"
)

type UserResponse struct {
	Name string
}

type userGetter interface {
	GetUser(ctx context.Context, id model.ID) (model.User, error)
}

func User(r chi.Router, db userGetter) {
	r.Get("/user", httph.JSONHandler(func(w http.ResponseWriter, r *http.Request, _ any) (UserResponse, error) {
		id := r.URL.Query().Get("id")
		user, err := db.GetUser(r.Context(), model.ID(id))
		if err != nil {
			return UserResponse{}, httph.HTTPError{Code: http.StatusInternalServerError, Err: errors.New("error getting user")}
		}
		return UserResponse{Name: user.Name}, nil
	}))
}

```

### Tests

I write tests for most functions and methods. I almost always use subtests with a good description of whats is going on and what the expected result is.

Here's an example:

```go example.go
package example

type Thing struct {}

func (t *Thing) DoSomething() (bool, error) {
	return true, nil
}
```

```go example_test.go
package example_test

import (
	"testing"

	"maragu.dev/is"

	"example"
)

func TestThing_DoSomething(t *testing.T) {
	t.Run("should do something and return a nil error", func(t *testing.T) {
		thing := &example.Thing{}

		ok, err := thing.DoSomething()
		is.NotError(t, err)
		is.True(t, ok)
	})
}
```

Sometimes I use table-driven tests:

```go example.go
package example

import "errors"

type Thing struct {}

var ErrChairNotSupported = errors.New("chairs not supported")

func (t *Thing) DoSomething(with string) error {
	if with == "chair" {
		return ErrChairNotSupported
	}
	return nil
}
```

```go example_test.go
package example_test

import (
	"testing"

	"maragu.dev/is"

	"example"
)

func TestThing_DoSomething(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected error
	}{
		{name: "should do something with the table and return a nil error", input: "table", expected: nil},
		{name: "should do something with the chair and return an ErrChairNotSupported", input: "chair", expected: example.ErrChairNotSupported},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			thing := &example.Thing{}

			err := thing.DoSomething(test.input)
			if test.expected != nil {
				is.Error(t, test.expected, err)
			} else {
				is.NotError(t, err)
			}
		})
	}
}
```

I prefer integration tests with real dependencies over mocks, because there's nothing like the real thing. Dependencies are typically run in Docker containers. You can assume the dependencies are running when running tests.

It makes sense to use mocks when the important part of a test isn't the dependency, but it plays a smaller role. But for example, when testing database methods, a real underlying database should be used.

I use test assertions with the module `maragu.dev/is`. Available functions: `is.True`, `is.Equal`, `is.Nil`, `is.NotNil`, `is.EqualSlice`, `is.NotError`, `is.Error`. All of these take an optional message as the last parameter.

Since tests are shuffled, don't rely on test order, even for subtests.

Every time the `postgrestest.NewDatabase(t)`/`sqlitetest.NewDatabase(t)` test helpers are called, the database is in a clean state (no leftovers from other tests etc.).

You can use database fixtures for tests. Prefer these for test data setups when multiple tests rely on the same or very similar data, so that every test doesn't have to set up the same data. They are in `sqlite/testdata/fixtures`/`postgres/testdata/fixtures`. Use them with `sqlitetest.NewDatabase(t, sqlitetest.WithFixtures("fixture one", "fixture two"))`. They are applied in the order given.

### Miscellaneous

- Variable naming:
  - `req` for requests, `res` for responses
- Prefer lowercase SQL queries
- There are SQL helpers available, at `Database.H.Select`, `Database.H.Exec`, `Database.H.Get`, `Database.H.InTx`.
- Use the `any` builtin in Go instead of `interface{}`
- There's an alias for `sql.ErrNoRows` from stdlib at `maragu.dev/glue/sql.ErrNoRows`, so you don't have to import both
- In tests, use `t.Context()` instead of `context.Background()`
- Test helper functions should call `testing.T.Helper()`
- All HTML buttons need the `cursor-pointer` CSS class
- SQLite time format is always a string returned by `strftime('%Y-%m-%dT%H:%M:%fZ')`
- Remember that private functions in Go are package-level, so you can use them across files in the same package
- Lowercase the beginning of HTML component names unless they need to be used by an HTTP handler outside the package
- Documentation should follow the Go style of having the identifier name be the first word of the sentence, and then completing the sentence without repeating itself. Example: "// SearchProducts using the given search query and result limit." NOT: "// SearchProducts searches products using the given search query and result label."
- Package-level identifiers should begin with lowercase by default, i.e. have package-level visibility, to make the API surface area towards other packages smaller. In particular, HTML components should be internal to the package unless needed by an HTTP handler.

## Testing, linting, evals

Run `make test` or `go test -shuffle on ./...` to run all tests. To run tests in just one package, use `go test -shuffle on ./path/to/package`. To run a specific test, use `go test ./path/to/package -run TestName`.

Run `make lint` or `golangci-lint run` to run linters. They should always be run on the package/directory level, it won't work with single files.

Run `make eval` or `go test -shuffle on -run TestEval ./...` to run LLM evals.

Run `make fmt` to format all code in the project, which is useful as a last finishing touch.

You can access the database by using `psql` or `sqlite3` in the shell.

## Version control

When writing commit messages, surround identifier names (variable names, type names, etc.) in backticks. Include the package name when refering to indentifiers. Example: `model.User`.

## Bugs

If you think you've found a bug during testing, ask me what to do, instead of trying to work around the bug in tests.

## Documentation

You can generally look up documentation for a Go module using `go doc` with the module name. For example, `go doc net/http` for something in the standard library, or `go doc maragu.dev/gai` for a third-party module. You can also look up more specific documentation for an identifier with something like `go doc maragu.dev/gai.ChatCompleter`, for the `ChatCompleter` interface.

## Checking apps in a browser

You can assume the app is running and available in a browser using the Chrome Dev Tools MCP tool. It auto-reloads on code changes so you don't have to.
Log output from the running application is in `app.log` in the project root.
