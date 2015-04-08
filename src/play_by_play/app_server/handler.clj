(ns play-by-play.app-server.handler
  (:require [play-by-play.season :as season]
            [play-by-play.app-server.logging :refer :all]
            [ring.middleware.stacktrace :refer :all]
            [ring.middleware.reload :refer :all]
            [ring.util.response :as resp]
            [compojure.core :refer :all]
            [compojure.handler :as handler]
            [compojure.route :as route]
            [cheshire.core :as cheshire]
            [clojure.string :as str]))

(defn to-camel-case [k]
  (let [s (if (keyword? k) (name k) k)]
    (str/replace s #"\-[A-z]" (fn [[dash letter]]
                            (.toUpperCase (str letter))))))

(defn index-json [request]
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body (cheshire/encode season/day {:key-fn (fn [k] (to-camel-case (name k)))})})

(defroutes app-routes
  (GET "/index.json" [] index-json)
  (GET "/" [] (resp/resource-response "index.html" {:root "public"}))
  (route/resources "/" ))

(def app
 (-> #'app-routes
   (wrap-request-logging)
   (wrap-reload '[play-by-play.app-server.handler])
   (wrap-stacktrace)))
