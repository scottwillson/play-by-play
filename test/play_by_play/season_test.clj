(ns play-by-play.season-test
  (:require [clojure.test :refer :all]
            [incanter.stats :as stats]
            [play-by-play.assertions :refer :all]
            [play-by-play.season :refer :all]))

(defn unique-teams [season]
  (set
    (flatten
      (map :name
        (flatten
          (map :teams season))))))

(deftest test-season
  (testing "full slate of games for 2012"
    (is (= 1229 (count season))))

  (testing "all teams play games"
    (is (= 30
      (count (unique-teams season)))))

  (testing "realistic average home score"
    (let [average-score (stats/mean (map #(:points (first (:teams %))) season))]
      (is (>= average-score 95))
      (is (<= average-score 99))))

  (testing "realistic average visitor score"
    (let [average-score (stats/mean (map #(:points (last (:teams %))) season))]
      (is (>= average-score 95))
      (is (<= average-score 99))))

  (testing "realistic game scores"
    (is (every? realistic-game-score? season))))
