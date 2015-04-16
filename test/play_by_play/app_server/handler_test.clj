(ns play-by-play.app-server.handler-test
  (:require [clojure.test :refer :all]
            [cheshire.core :as json]
            [ring.mock.request :refer :all]
            [play-by-play.app-server.handler :refer :all]))

(deftest test-index
  (testing "index HTML"
    (let [response (app (request :get "/"))]
      (is (= (:status response) 200))
      (is (re-find #"material.init" (slurp (:body response))))))

  (testing "index JSON"
    (let [response (app (request :get "/index.json?date=2012-10-30"))]
      (is (= (:status response) 200))
      (is (= "Cleveland Cavaliers"
        (:name (last (:teams (first
          (json/parse-string (:body response) true))))))))))

(deftest test-box-score
  (testing "HTML"
    (let [response (app (request :get "/box_score.html"))]
      (is (= (:status response) 200))
      (is (re-find #"material.init" (slurp (:body response))))))

  (testing "JSON"
    (let [response (app (request :get "/box_score.json"))
          plays (:plays response)]
      (is (= (:status response) 200))
      (is (= "Washington Wizards"
        (:name (first (:teams
          (json/parse-string (:body response) true))))))
      (is (> plays) 0))))
