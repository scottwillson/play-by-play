(ns play-by-play.game-test
  (:require [clojure.test :refer :all]
            [incanter.stats :as stats]
            [play-by-play.assertions :refer :all]
            [play-by-play.game :refer :all]))

(deftest test-box-score
  (testing "should total player points"
    (let [game {:teams [{:name "Bulls"} {:name "Cavs"}]}
          team (first (:teams (box-score game)))
          players (:players team)]
    (is (=
         (reduce + (map :points players))
         (:points team))))))

(deftest test-player
  (testing "name length"
   (is
     (> (count
       (:name (player))) 3)))

   (testing "points"
     (is
       (>= (:points (player))) 0)))
