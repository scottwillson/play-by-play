(ns play-by-play.app-server.handler
  (:require [play-by-play.real-world :as rw]
            [play-by-play.season :as season]
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

(defn box-score-json [request]
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body (json/to-json
     [
       {
         :name "Washington Wizards"
         :location "visitor"
         :points 101
         :players (repeatedly 15 #(rw/player))
       }
       {
         :name "Cleveland Cavaliers"
         :location "home"
         :points 113
         :players (repeatedly 15 #(rw/player))}])})

(defroutes app-routes
  (GET "/index.json" [date] (index-json date))
  (GET "/box_score.json" [] box-score-json)
  (GET "/" [] (resp/resource-response "index.html" {:root "public"}))
  (route/resources "/" ))

(def app
 (-> #'app-routes
   (wrap-request-logging)
   (wrap-params)
   (wrap-reload '[play-by-play.app-server.handler])
   (wrap-stacktrace)))
