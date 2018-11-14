{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Raft.Persistent where

import Protolude
import qualified Data.Serialize as S

import Raft.Types

-- | The type class specifying how to read and write the persistent state to
-- disk.
--
-- Law: writePersistentState p >> readPersistentState == p
class Monad m => RaftPersist m where
  type RaftPersistError m
  readPersistentState
    :: Exception (RaftPersistError m)
    => m (Either (RaftPersistError m) PersistentState)
  writePersistentState
    :: Exception (RaftPersistError m)
    => PersistentState -> m (Either (RaftPersistError m) ())

-- | Persistent state that all Raft nodes maintain, regardless of node state.
data PersistentState = PersistentState
  { currentTerm :: Term
    -- ^ Last term server has seen
  , votedFor :: Maybe NodeId
    -- ^ candidate id that received vote in current term
  } deriving (Show, Generic, S.Serialize)

initPersistentState :: PersistentState
initPersistentState = PersistentState
  { currentTerm = term0
  , votedFor = Nothing
  }
