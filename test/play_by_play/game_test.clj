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

(deftest test-add-plays
  (testing "plays"
    (let [game {}]
    (is (> (count (:plays (add-plays game))) 20)))))

(deftest test-create-plays
  (testing "plays"
    (let [play (create-play {})]
    (is (not (nil? (:name play)))))))
