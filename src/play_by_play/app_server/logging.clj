(ns play-by-play.app-server.logging
  (:require [compojure.core])
  (:require [ring.middleware.file]))

(defn- log [msg & vals]
    (let [line (apply format msg vals)]
          (locking System/out (println line))))

(defn wrap-request-logging [handler]
    (fn [{:keys [request-method uri] :as req}]
          (let [start (System/currentTimeMillis)
                          resp   (handler req)
                          finish (System/currentTimeMillis)
                          total  (- finish start)]
                  (log "request %s %s (%dms)" request-method uri total)
                  resp)))

