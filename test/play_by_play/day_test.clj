(ns play-by-play.day-test
  (:require [clojure.test :refer :all]
            [play-by-play.season :refer :all]))

(deftest test-day
  (testing "games for one day"
    (is (> (count day) 1))))
