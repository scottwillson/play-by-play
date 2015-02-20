(ns play-by-play.season-test
  (:require [clojure.test :refer :all]
            [incanter.stats :as stats]
            [play-by-play.assertions :refer :all]
            [play-by-play.season :refer :all]))

(defn unique-teams [season]
  (map home-team season))

(deftest test-score
  (testing "game score"
    (is (realistic-game-score? score)))

(deftest test-season
  (testing "full slate of games"
    (is (= 1260 (count season)))))

  (testing "all teams play games")
    (is (= 30 (unique-teams season)))

  (testing "realistic average score"
    (let [average-score (stats/mean (flatten season))]
      (is (and
        (> average-score 95)
        (< average-score 99)))))

  (testing "realistic game scores"
    (is (every? #(realistic-game-score? %) season))))
