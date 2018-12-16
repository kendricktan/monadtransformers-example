{-# LANGUAGE ConstraintKinds            #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Main where

import           Control.Monad
import           Control.Monad.Except
import           Control.Monad.Reader
import           Control.Monad.State.Lazy

-- | Monad Declaration (ReaderT -> StateT -> ExceptT)
--
data MyEnvironment = MyEnvironment
  { envStr :: String
  , envInt :: Int
  } deriving Show

data MyState = MyState
  { stateStr :: String
  , stateInt :: Int
  } deriving Show

data MyError = ErrorNumberOne
             | ErrorNumberTwo
             | UnknownError
             deriving Show

newtype MyMonad a = MyMonad (ReaderT MyEnvironment (StateT MyState (ExceptT MyError IO)) a)
  deriving ( Functor
           , Applicative
           , Monad
           , MonadReader MyEnvironment
           , MonadState MyState
           , MonadError MyError
           , MonadIO
           )

-- Helper functions
--
runMyMonad :: MyEnvironment -> MyState -> MyMonad a -> IO (Either MyError a)
runMyMonad env state (MyMonad m) = runExceptT s
  where r = runReaderT m env
        s = evalStateT r state

initialEnvironment :: MyEnvironment
initialEnvironment = MyEnvironment "Gotta go fast" 42

initialState :: MyState
initialState = MyState "Double Cheese Burgers" 0

-- | Usage Examples
--

-- Reads from environment and outputs to stdout
-- printEnvValue and printEnvValue' are the same
-- just with/without the do syntax sugar
printEnvValue :: MyMonad ()
printEnvValue = ask >>= liftIO . print

printEnvValue' :: MyMonad ()
printEnvValue' = do
  r <- ask
  liftIO . print $ r

printStateValue :: MyMonad ()
printStateValue = get >>= liftIO . print

printStateValue' :: MyMonad ()
printStateValue' = do
  s <- get
  liftIO . print $ s

-- If its given an even value, it'll update
-- the state value to the given value,
-- otherwise it'll update the state value
-- to be the same value from the Environment (reader)

envReadStateUpdate :: Int -> MyMonad ()
envReadStateUpdate i = do
  -- Print State Value
  liftIO $ putStrLn "Initial state value: "
  printStateValue
  case i `rem` 2 of
     -- Updates stateInt value
     0 -> modify (\s -> s { stateInt = i } )
     _ -> do
       -- Gets the environment's Int value
       r <- asks envInt
       modify (\s -> s { stateInt = r } )
  liftIO $ putStrLn "Final state value: "
  printStateValue'

-- Exception handling
errorHandler :: MyError -> MyMonad ()
errorHandler ErrorNumberOne = modify (\s -> s { stateInt = 1 })
errorHandler ErrorNumberTwo = modify (\s -> s { stateInt = 2 })
errorHandler UnknownError   = modify (\s -> s { stateInt = -1 })

logicHandler :: Int -> MyMonad ()
logicHandler i = case i `rem` 3 of
                  0 -> liftIO (putStrLn "Divisible by 3!") >> return ()
                  1 -> throwError ErrorNumberOne
                  2 -> throwError ErrorNumberTwo
                  _ -> throwError UnknownError

handleExceptions :: [Int] -> MyMonad ()
handleExceptions []       = return ()
handleExceptions (x : xs) = do
  liftIO $ putStrLn $ "Obtained integer: " ++ (show x)
  liftIO $ putStrLn "Initial state value: "
  printStateValue
  (logicHandler x) `catchError` (\e -> liftIO (putStrLn "Not divisible by 3!") >> errorHandler e)
  liftIO $ putStrLn "Final state value: "
  printStateValue
  liftIO $ putStrLn "===================== "
  handleExceptions xs


main :: IO ()
main = do
  putStrLn "1. Reads environment value and outputs to stdout:"
  _ <- runMyMonad initialEnvironment initialState printEnvValue
  putStrLn "\n\n2. Reads state value and outputs to stdout"
  _ <- runMyMonad initialEnvironment initialState printStateValue
  putStrLn "\n\n3. Updates state value to 16 (since it's an even number)"
  _ <- runMyMonad initialEnvironment initialState (envReadStateUpdate 16)
  putStrLn "\n\n4. Updates state value to whatever reader Int is (since it's an odd number)"
  _ <- runMyMonad initialEnvironment initialState (envReadStateUpdate 3)
  putStrLn "\n\n5. Exception handling"
  _ <- runMyMonad initialEnvironment initialState (handleExceptions [2..5])
  return ()
