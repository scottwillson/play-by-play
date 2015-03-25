(ns play-by-play.app-server.handler-test
  (:require [clojure.test :refer :all]
            [cheshire.core :as json]
            [ring.mock.request :refer :all]
            [play-by-play.app-server.handler :refer :all]))

(deftest test-app
  (testing "index HTML"
    (let [response (app (request :get "/"))]
      (is (= (:status response) 200))
      (is (re-find #"Final" (slurp (:body response))))))

  (testing "index JSON"
    (let [response (app (request :get "/index.json"))]
      (is (= (:status response) 200))
      (is (= "New Orleans" (:team
        (first (json/parse-string (:body response) true))))))))
