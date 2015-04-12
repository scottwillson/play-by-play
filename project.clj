(defproject play-by-play "0.1.0-SNAPSHOT"
  :description "Basketball simulation"
  :url "http://rocketsurgeryllc.com"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.clojure/data.csv "0.1.2"]
                 [org.clojure/tools.cli "0.3.1"]
                 [cheshire "5.4.0"]
                 [clj-time "0.9.0"]
                 [incanter "1.5.6"]
                 [ring "1.3.2"]
                 [compojure "1.3.2"]]
  :main ^:skip-aot play-by-play.core
  :target-path "target/%s"
  :plugins [[lein-ring "0.9.3"] [quickie "0.3.9"]]
  :repl-options {:nrepl-middleware [lighttable.nrepl.handler/lighttable-ops]}
  :ring {:handler play-by-play.app-server.handler/app}
  :profiles
    {:uberjar {:aot :all}
     :dev     {:dependencies [[lein-light-nrepl "0.1.0"]
                              [ring-mock "0.1.5"]
                              [org.mortbay.jetty/jetty "6.1.26"]
                              [clj-webdriver "0.6.1"]]}}
  :test-selectors {:default (complement :browser)
                   :browser :browser
                   :all     (constantly true)}
  :test-matcher #".*^(browser)")
