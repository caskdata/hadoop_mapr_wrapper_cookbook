# hadoop_mapr wrapper cookbook

# Description

This cookbook is a wrapper cookbook for the [Hadoop_mapr cookbook](https://github.com/caskdata/hadoop_mapr_cookbook).  It is a part of [Coopr](https://github.com/caskdata/coopr), which is a general purpose tool that can spin up several types of clusters including MapR Hadoop.  This cookbook provides several initialization recipes for MapR/Hadoop components.  It does not actually start any of the MapR services.  This can be done by wrapping the service resources in the underlying [Hadoop_mapr cookbook](https://github.com/caskdata/hadoop_mapr_cookbook), for example:
```ruby
    ruby_block "start warden" do
      block do
        resources("mapr-warden").run_action(:start)
      end 
    end
```

Additional information on how to wrap cookbooks in general can be found in the [Hadoop cookbook wiki](https://github.com/caskdata/hadoop_cookbook/wiki/Wrapping-this-cookbook).

# Requirements

This cookbook may work on earlier versions, but these are the minimal tested versions:

* Chef 11.16.4+
* CentOS 6.6+
* Ubuntu 12.04+


# Cookbook Dependencies

* hadoop_mapr
* mysql
* database

# Attributes

There are no attributes specific to this cookbook, however we set many default attributes for the underlying cookbooks in order to have a reasonably configured MapR cluster.  Be sure to look at the attributes files and override as desired.

# Usage

Include the relevant recipes in your run-list.

# Author

Author:: Cask Data, Inc. (<ops@cask.co>)

# License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this software except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
