(ns surprisebuild.surprisebuildweb2.core
  (:require
   [clojure.tools.logging :as log]
   [integrant.core :as ig]
   [surprisebuild.surprisebuildweb2.config :as config]
   [surprisebuild.surprisebuildweb2.env :refer [defaults]]

    ;; Edges
   [kit.edge.server.undertow]
   [surprisebuild.surprisebuildweb2.web.handler]

    ;; Routes
   [surprisebuild.surprisebuildweb2.web.routes.api] 
    [surprisebuild.surprisebuildweb2.web.routes.pages])
  (:gen-class))

;; log uncaught exceptions in threads
(Thread/setDefaultUncaughtExceptionHandler
 (fn [thread ex]
   (log/error {:what :uncaught-exception
               :exception ex
               :where (str "Uncaught exception on" (.getName thread))})))

(defonce system (atom nil))

(defn stop-app []
  ((or (:stop defaults) (fn [])))
  (some-> (deref system) (ig/halt!)))

(defn start-app [& [params]]
  ((or (:start params) (:start defaults) (fn [])))
  (->> (config/system-config (or (:opts params) (:opts defaults) {}))
       (ig/expand)
       (ig/init)
       (reset! system)))

(defn -main [& _]
  (start-app)
  (.addShutdownHook (Runtime/getRuntime) (Thread. (fn [] (stop-app) (shutdown-agents)))))
