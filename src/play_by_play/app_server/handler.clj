(ns play-by-play.app-server.handler
  (:require [play-by-play.season :as season]
            [play-by-play.strings :as strings]
            [play-by-play.hashes :as hashes]
            [play-by-play.app-server.logging :refer :all]
            [ring.middleware.params :refer :all]
            [ring.middleware.stacktrace :refer :all]
            [ring.middleware.reload :refer :all]
            [ring.util.response :as resp]
            [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]
            [cheshire.core :as cheshire]))

(defn to-json [object]
  (cheshire/encode object {:key-fn hashes/to-camel-case-keys}))

(defn index-json [date]
  (println date)
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body (to-json (season/day date))})

(defroutes app-routes
  (GET "/index.json" [date] (index-json date))
  (GET "/" [] (resp/resource-response "index.html" {:root "public"}))
  (route/resources "/" ))

(def app
 (-> #'app-routes
   (wrap-request-logging)
   (wrap-params)
   (wrap-reload '[play-by-play.app-server.handler])
   (wrap-stacktrace)))
