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

(deftest test-box-score
  (testing "should total player points"
    (let [game {:teams [{:name "Bulls"} {:name "Cavs"}]}
          team (first (:teams (box-score game)))
          players (:players team)]
    (is (=
         (reduce + (map :points players))
         (:points team))))))

(deftest test-season
  (testing "full slate of games for 2012"
    (is (= 1229 (count season))))

  (testing "all teams play games"
    (is (= 30
      (count (unique-teams season)))))

  (testing "realistic average home score"
    (let [average-score (stats/mean (map #(:points (first (:teams %))) season))]
      (is (and
        (>= average-score 95)
        (<= average-score 99)))))

  (testing "realistic average visitor score"
  (let [average-score (stats/mean (map #(:points (last (:teams %))) season))]
      (is (and
        (>= average-score 95)
        (<= average-score 99)))))

  (testing "realistic game scores"
    (is (every? realistic-game-score? season))))

(deftest test-player
  (testing "name length"
    (is
      (> (count
        (:name (player))) 3)))

    (testing "points"
      (is
        (>= (:points (player))) 0)))
