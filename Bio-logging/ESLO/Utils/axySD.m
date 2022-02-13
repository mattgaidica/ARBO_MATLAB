function SD = axySD(intervalData)
intervalData = double(intervalData);
SD = std(intervalData(:,1)) + std(intervalData(:,2)) + std(intervalData(:,3));