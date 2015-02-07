(ns play-by-play.core-test
  (:require [clojure.test :refer :all]
            [play-by-play.core :refer :all]))

(deftest test-score
  (testing "game score"
    (is (= [0, 0] score))))
