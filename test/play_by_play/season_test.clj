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

(deftest test-score
  (testing "realistic score"
    (is (realistic-score? (score)))))

(deftest test-season
  (testing "full slate of games"
    (is (= 1260 (count season))))

  (testing "all teams play games"
    (is (= 30
      (count (unique-teams season)))))

  (testing "realistic average home score"
    (let [average-score (stats/mean (map :home-score season))]
      (is (and
        (>= average-score 95)
        (<= average-score 99)))))

  (testing "realistic average visitor score"
    (let [average-score (stats/mean (map :visitor-score season))]
      (is (and
        (>= average-score 95)
        (<= average-score 99)))))

  (testing "realistic game scores"
    (is (every? #(realistic-game-score? %) season))))

(deftest test-team
  (testing "team returns a team name"
    (is (> (count (team))
      5))))
