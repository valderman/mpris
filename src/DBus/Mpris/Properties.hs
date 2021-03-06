{-# LANGUAGE OverloadedStrings #-}

-- | Utilities to work with dbus properties.
--
-- A very simple api to org.freedesktop.DBus.Properties.
module DBus.Mpris.Properties
       ( getProperty
       , setProperty
       ) where

import DBus

import DBus.Mpris.Monad
import DBus.Mpris.Utils
import Control.Monad.Trans (liftIO)

-- | Construct a call to get value of property at interface
getPropertyCall :: String     -- ^ Interface
             -> String     -- ^ Property name
             -> MethodCall
getPropertyCall interface property = (methodCall "/org/mpris/MediaPlayer2" "org.freedesktop.DBus.Properties" "Get")
  { methodCallBody = [toVariant interface, toVariant property] }

-- | Get value of interface's property at bus
getProperty :: IsVariant a =>
               String  -- ^ Interface
            -> String  -- ^ Property
            -> BusName -- ^ Bus
            -> Mpris (Maybe a)
getProperty interface prop bus = do
  reply <- call $ getPropertyCall interface prop `to` bus
  case reply of
    Left e   -> liftIO $ print e >> return Nothing
    Right (Left e) -> liftIO $ print e >> return Nothing
    Right (Right r) -> do
      let body = methodReturnBody r
      -- the bind here runs inside Maybe monad, neat!
      return $ fromVariant (head body) >>= fromVariant

-- | Construct a call to set value of property at interface
setPropertyCall :: IsVariant a =>
                   String     -- ^ Interface
                -> String     -- ^ Property name
                -> a          -- ^ Value
                -> MethodCall
setPropertyCall interface property value = (methodCall "/org/mpris/MediaPlayer2" "org.freedesktop.DBus.Properties" "Set")
  { methodCallBody = [ toVariant interface
                     , toVariant property
                     , toVariant value ] }

-- | Get value of interface's property at bus
setProperty :: IsVariant a =>
               String  -- ^ Interface
            -> String  -- ^ Property
            -> BusName -- ^ Bus
            -> a       -- ^ Value
            -> Mpris ()
setProperty interface prop bus value = do
  reply <- call $ setPropertyCall interface prop value `to` bus
  case reply of
    Left e   -> liftIO $ print e
    Right (Left e) -> liftIO $ print e
    Right (Right r) -> return ()
