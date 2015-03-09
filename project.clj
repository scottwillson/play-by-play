(defproject play-by-play "0.1.0-SNAPSHOT"
  :description "Basketball simulation"
  :url "http://rocketsurgeryllc.com"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.clojure/tools.cli "0.3.1"]
                 [org.clojure/data.csv "0.1.2"]
                 [incanter "1.5.6"]]
  :main ^:skip-aot play-by-play.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
