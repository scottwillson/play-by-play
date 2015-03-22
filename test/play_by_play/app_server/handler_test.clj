(ns play-by-play.app-server.handler-test
  (:require [clojure.test :refer :all]
            [ring.mock.request :refer :all]
            [play-by-play.app-server.handler :refer :all]))

(deftest test-app
  (testing "main route"
    (let [response (app (request :get "/"))]
      (is (= (:status response) 200))
      (is (= "[]" (:body response))))))
