(ns play-by-play.game-test
  (:require [clojure.test :refer :all]
            [incanter.stats :as stats]
            [play-by-play.assertions :refer :all]
            [play-by-play.game :refer :all]))

(deftest test-box-score
  (testing "should total player points"
    (let [game {:teams [{:name "Bulls"} {:name "Cavs"}]}
          box (box-score game)
          team (first (:teams box))
          plays (:plays box)
          players (:players team)]
    (is (=
          (reduce + (map :points players))
          (reduce + (map :points (filter #(= (:team %) "Bulls") plays)))
          (:points team))
        box))))

(deftest test-add-plays
  (testing "reasonable count of plays for a game"
    (let [game {}]
    (is (> (count (:plays (add-plays game))) 20)))))

(deftest test-create-plays
  (testing "all plays should have a :name"
    (let [play (create-play {})]
    (is (not (nil? (:name play)))))))
