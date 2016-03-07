#
# TeNOR - NS Manager
#
# Copyright 2014-2016 i2CAT Foundation, Portugal Telecom Inovação
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @see TnovaManager
class TnovaManager < Sinatra::Application

  def updateStatistics(name)
    begin
      @statistic = StatisticModel.find_by(:name => name)
      val = @statistic['value'].to_i + 1
      @statistic.update_attribute(:value, val)
    rescue Mongoid::Errors::DocumentNotFound => e
      StatisticModel.new(:name => name, :value => 1).save!
    end

  end

  def savePerformance(instance)

    mapping_time = (DateTime.parse(instance['mapping_time']).to_time.to_f*1000 - DateTime.parse(instance['created_at']).to_time.to_f*1000).to_s
    instantiation_time = (DateTime.parse(instance['instantiation_end_time']).to_time.to_f*1000 - DateTime.parse(instance['instantiation_start_time']).to_time.to_f*1000).to_s
    final_time = (DateTime.parse(instance['instantiation_end_time']).to_time.to_f*1000 - DateTime.parse(instance['created_at']).to_time.to_f*1000).to_s

    @stats = {
        :instance_id => instance['id'],
        :created_at => DateTime.parse(instance['created_at']).to_time.to_f*1000,
        :mapping => mapping_time,
        :instantiation => instantiation_time,
        :total => final_time
    }

    @statistic = PerformanceStatisticModel.new(@stats).save!

  end

end