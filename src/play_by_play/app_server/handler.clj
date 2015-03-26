(ns play-by-play.app-server.handler
  (:require [play-by-play.app-server.logging :refer :all]
            [ring.middleware.stacktrace :refer :all]
            [ring.middleware.reload :refer :all]
            [ring.util.response :as resp]
            [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]))

(defn index-json [request]
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body "[{
     \"homeTeam\": \"New Orleans\",
     \"homeScore\": 100,
     \"visitorTeam\": \"New York\",
     \"visitorScore\": 99}]"})

(defroutes app-routes
  (GET "/index.json" [] index-json)
  (GET "/" [] (resp/resource-response "index.html" {:root "public"}))
  (route/resources "/" ))

(def app
 (-> #'app-routes
   (wrap-request-logging)
   (wrap-reload '[play-by-play.app-server.handler])
   (wrap-stacktrace)))
