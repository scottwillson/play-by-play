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

  (testing "max scores"
    (is (every? #(realistic-game-score? %) season))))
