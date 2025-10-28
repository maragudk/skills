---
name: git
description: Guide for using git according to my preferences. Use it when you're asked to commit something.
license: MIT
---

# git

Most of git usage is what you already know, so depend on that. This is skill is just a refinement.

## Branch naming

Just name the branch a short sentence seperated with dashes. Example: `add-some-feature`. Don't use `feat/`, `hotfix/` etc. prefixes.

## Commit messages

- Always enclose code identifiers with backticks. Example: "Add `html.UserPage` component"
- Always refer to Go code identifiers with the package name included, like in `html.UserPage` above. Fields on structs can be referred with `model.User.Name`.
- Ask me about any Github issues that should be referenced. Reference them at the end of the commit message like this: "See #123, #234"
