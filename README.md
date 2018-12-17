# monadtransformers-example
StateT, ReaderT, and ExceptT usage example

Primarily for the following pattern:
`Env -> State -> IO (Either Error a)`

# Running the example
```bash
# Get Nix (if you haven't already)
curl https://nixos.org/nix/install | sh

nix-shell

# For GHCI
cabal v2-repl

# To run project
cabal v2-run monadtransformers-example
```
