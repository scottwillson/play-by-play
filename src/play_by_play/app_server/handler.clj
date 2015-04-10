(ns play-by-play.app-server.handler
  (:require [play-by-play.season :as season]
            [play-by-play.app-server.date-conversion :as dates]
            [play-by-play.app-server.json-conversion :as json]
            [play-by-play.app-server.logging :refer :all]
            [ring.middleware.params :refer :all]
            [ring.middleware.stacktrace :refer :all]
            [ring.middleware.reload :refer :all]
            [ring.util.response :as resp]
            [compojure.core :refer :all]
            [compojure.route :as route]))

(defn index-json [date]
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body (json/to-json (season/day (dates/parse-string date)))})

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
