function yearlyWeather = getWeatherData()
    weatherPath = 'Data/weatherData';
    monthProto = '-Table 1.csv';
    monthNames = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};

    yearlyWeather = [];
    dayCount = 0;
    for iMonth = 1:numel(monthNames)
        T = readtable(fullfile(weatherPath,[monthNames{iMonth},monthProto]));
        for iDay = 1:size(T,1)
            dayCount = dayCount + 1;
            yearlyWeather(dayCount) = f2c(T.Avg(iDay));
        end
    end

end

function C = f2c(F)
    C = (5/9)*(F-32);
end