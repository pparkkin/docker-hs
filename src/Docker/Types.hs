module Docker.Types where

import           Control.Monad.Except (ExceptT, runExceptT)
import           Control.Monad.Reader (ReaderT, runReaderT)
import           Data.Aeson           (FromJSON, ToJSON, encode,
                                       genericParseJSON, genericToJSON,
                                       parseJSON, toJSON)
import           Data.Aeson.Types     (defaultOptions, fieldLabelModifier)
import qualified Data.ByteString.Lazy as BL
import           Data.Char            (toUpper)
import           Data.Text            (Text)
import qualified Data.Text            as T
import           GHC.Generics         (Generic)
import qualified Network.HTTP.Client  as HTTP

type Endpoint = Text
type URL = Text
type ApiVersion = Text
type ContainerID = Text
type ImageID = Text
type Timeout = Integer

type Request = HTTP.Request
type Response = HTTP.Response BL.ByteString

data Signal = SIGINT | SIGKILL deriving (Eq, Show)

data DockerClientOpts m = DockerClientOpts {
      http       :: Request -> m Response
    , apiVersion :: ApiVersion
    , baseUrl    :: URL
    }

type DockerT m a = ReaderT (DockerClientOpts m) (ExceptT String m) a

runDockerT :: (Monad m) => DockerClientOpts m -> DockerT m a -> m (Either String a)
runDockerT opts a = runExceptT $ runReaderT a opts
-- runDockerT opts a = (runExceptT .) . flip runReaderT opts a

data ListOpts = ListOpts { all :: Bool } deriving (Eq, Show)

defaultClientOpts :: DockerClientOpts IO
defaultClientOpts = DockerClientOpts {
                  http = undefined
                , apiVersion = "v1.22"
                , baseUrl = "http://127.0.0.1:2375/"
                }

data DockerVersion = DockerVersion {
                    version       :: Text
                  , gitCommit     :: Text
                  , goVersion     :: Text
                  , arch          :: Text
                  , kernelVersion :: Text
                  } deriving (Show, Eq, Generic)


instance ToJSON DockerVersion where
    toJSON = genericToJSON defaultOptions {
         fieldLabelModifier = (\(x:xs) -> toUpper x : xs)}

instance FromJSON DockerVersion where
    parseJSON = genericParseJSON defaultOptions {
            fieldLabelModifier = (\(x:xs) -> toUpper x : xs)}


data Container = Container

data Image = Image

data CreateOpts = CreateOpts
data StartOpts = StartOpts

data DeleteOpts = DeleteOpts {
                  v     :: Bool
                , force :: Bool
                } deriving (Eq, Show)

type Timestamp = Integer
data Tail = Integer | All deriving (Eq, Show)

data LogOpts = LogOpts {
               follow     :: Bool
             , stdout     :: Bool
             , stderr     :: Bool
             , since      :: Timestamp
             , timestamps :: Bool
             , tail       :: Tail
             } deriving (Eq, Show)
