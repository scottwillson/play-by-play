(ns play-by-play.core-test
  (:require [clojure.test :refer :all]
            [play-by-play.assertions :refer :all]
            [play-by-play.core :refer :all]))

(deftest test-score
  (testing "game score"
    (is (realistic-game-score? score)))

(deftest test-season
  (testing "full slate of games"
    (is (= 1260 (count season)))))

  (testing "realistic average score"
    (let [average-score (average (flatten season))]
      (is (and
        (> average-score 95)
        (< average-score 99)))))

  (testing "realistic game scores"
    (is (every? #(realistic-game-score? %) season))))
