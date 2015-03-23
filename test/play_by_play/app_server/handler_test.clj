(ns play-by-play.app-server.handler-test
  (:require [clojure.test :refer :all]
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
      (is (= "[]" (:body response))))))
