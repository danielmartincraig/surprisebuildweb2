(ns surprisebuild.surprisebuildweb2.env
  (:require
    [clojure.tools.logging :as log]
    [surprisebuild.surprisebuildweb2.dev-middleware :refer [wrap-dev]]))

(def defaults
  {:init       (fn []
                 (log/info "\n-=[surprisebuildweb2 starting using the development or test profile]=-"))
   :start      (fn []
                 (log/info "\n-=[surprisebuildweb2 started successfully using the development or test profile]=-"))
   :stop       (fn []
                 (log/info "\n-=[surprisebuildweb2 has shut down successfully]=-"))
   :middleware wrap-dev
   :opts       {:profile       :dev}})
