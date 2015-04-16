(ns play-by-play.team-test
  (:require [clojure.test :refer :all]
            [play-by-play.team :refer :all]))

(deftest test-plays-for
  (testing "no plays"
    (let [game  {:plays []}
          plays (plays-for "Portland" game)]
    (is (= [] plays))))

  (testing "plays for different teams"
    (let [game  {:plays [{:team "Portland"}
                         {:team "Houston"}
                         {:team "Houston"}]}]
    (is (= 1 (count (plays-for "Portland" game))))
    (is (= 2 (count (plays-for "Houston" game)))))))

(deftest test-sum-points
  (testing "no plays"
    (let [game  {:plays []
                 :teams [{:name "Cleveland"} {:name "Washington"}]}]
    (is (= {:name "Cleveland" :points 0} (sum-points {:name "Cleveland"} game)))
    (is (= {:name "Washington" :points 0} (sum-points {:name "Washington"} game)))))

  (testing "plays for different teams"
    (let [game  {:plays [{:team "Houston", :points 2}
                         {:team "Houston", :points 3}
                         {:team "Portland", :points 2}]
                 :teams [{:name "Houston" } {:name "Portland"}]}]
    (is (= {:name "Houston" :points 5} (sum-points {:name "Houston"} game)))
    (is (= {:name "Portland" :points 2} (sum-points {:name "Portland"} game))))))

(deftest test-points-for
  (testing "no plays"
    (let [game  {:plays []
                 :teams [{:name "Cleveland" } {:name "Washington"}]}]
    (is (= 0 (points-for "Cleveland" game)))
    (is (= 0 (points-for "Washington" game)))))

  (testing "plays for different teams"
    (let [game  {:plays [{:team "Washington", :points 2}
                         {:team "Cleveland", :points 3}
                         {:team "Cleveland", :points 2}]}]
    (is (= 2 (points-for "Washington" game)))
    (is (= 5 (points-for "Cleveland" game))))))
