(ns play-by-play.app-server.date-conversion-test
  (:require [clojure.test :refer :all]
            [clj-time.core :as time]
            [clj-time.coerce :as time-coerce]
            [play-by-play.app-server.date-conversion :refer :all]))

(deftest test-parse-string
  (testing "date"
    (is (= (time-coerce/to-date (time/local-date 2015 11 16))
      (parse-string "2015-11-16"))))

  (testing "empty string"
    (is (nil? (parse-string nil)))))
