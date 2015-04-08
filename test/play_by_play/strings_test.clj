(ns play-by-play.strings-test
  (:require [play-by-play.strings :refer :all]
            [clojure.test :refer :all]))

(deftest test-to-camel-case
  (testing "empty string"
    (is (= "" (to-camel-case "")))))
