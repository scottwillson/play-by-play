(ns play-by-play.season-test
  (:require [clojure.test :refer :all]
            [incanter.stats :as stats]
            [play-by-play.assertions :refer :all]
            [play-by-play.season :refer :all]))

(defn unique-teams [season]
  (set
    (flatten [
      (map :home-team season)
      (map :visitor-team season)])))

(deftest test-random-score
  (testing "realistic score"
    (is (realistic-score? (random-score)))))

(deftest test-season
  (testing "full slate of games for 2012"
    (is (= 1229 (count (flatten season)))))

  (testing "all teams play games"
    (is (= 30
      (count (unique-teams (flatten season))))))

  (testing "realistic average home score"
    (let [average-score (stats/mean (map :home-score (flatten season)))]
      (is (and
        (>= average-score 95)
        (<= average-score 99)))))

  (testing "realistic average visitor score"
    (let [average-score (stats/mean (map :visitor-score (flatten season)))]
      (is (and
        (>= average-score 95)
        (<= average-score 99)))))

  (testing "realistic game scores"
    (is (every? #(realistic-game-score? %) (flatten season)))))
