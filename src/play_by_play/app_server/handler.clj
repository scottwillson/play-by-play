(ns play-by-play.app-server.handler
  (:require [play-by-play.season :as season]
            [play-by-play.strings :as strings]
            [play-by-play.app-server.logging :refer :all]
            [ring.middleware.stacktrace :refer :all]
            [ring.middleware.reload :refer :all]
            [ring.util.response :as resp]
            [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]
            [cheshire.core :as cheshire]))

(defn index-json [request]
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body (cheshire/encode season/day {:key-fn (fn [k] (strings/to-camel-case (name k)))})})

(defroutes app-routes
  (GET "/index.json" [] index-json)
  (GET "/" [] (resp/resource-response "index.html" {:root "public"}))
  (route/resources "/" ))

(def app
 (-> #'app-routes
   (wrap-request-logging)
   (wrap-reload '[play-by-play.app-server.handler])
   (wrap-stacktrace)))
