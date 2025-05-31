(ns surprisebuild.surprisebuildweb2.env
  (:require [clojure.tools.logging :as log]))

(def defaults
  {:init       (fn []
                 (log/info "\n-=[surprisebuildweb2 starting]=-"))
   :start      (fn []
                 (log/info "\n-=[surprisebuildweb2 started successfully]=-"))
   :stop       (fn []
                 (log/info "\n-=[surprisebuildweb2 has shut down successfully]=-"))
   :middleware (fn [handler _] handler)
   :opts       {:profile :prod}})
