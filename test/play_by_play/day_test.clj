(ns play-by-play.day-test
  (:require [clojure.test :refer :all]
            [play-by-play.season :refer :all]
            [clj-time.coerce :as time-coerce]
            [clj-time.core :as time]))

(deftest test-day
  (testing "games for October 30, 2012"
    (let [games (day (time-coerce/to-date (time/local-date 2012 10 30)))]
      (is (= 3 (count games))))))
