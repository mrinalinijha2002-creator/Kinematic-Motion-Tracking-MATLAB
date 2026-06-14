inputFile = 'Handvideo.mp4';
videoSource = VideoReader(inputFile);
outputFile = 'C:\Users\mrina\OneDrive\Desktop\Arm_Tracking_Fixed_Final.mp4';

outputVideo = VideoWriter(outputFile, 'MPEG-4');
outputVideo.FrameRate = videoSource.FrameRate;
open(outputVideo);

hFig = figure('Name', 'Arm Tracking');

while hasFrame(videoSource)
frame = readFrame(videoSource);

redIntensity = imsubtract(frame(:,:,1), rgb2gray(frame));

binaryMask = redIntensity > 50;

binaryMask = imclose(binaryMask, strel('disk', 15));

binaryMask = bwareaopen(binaryMask, 500);

stats = regionprops(binaryMask, 'Centroid');

annotatedFrame = frame;

if ~isempty(stats)
allPoints = cat(1, stats.Centroid);

sortedPts = sortrows(allPoints, 1);

if size(sortedPts, 1) > 3
sortedPts = sortedPts(1:3, :);
end

annotatedFrame = insertShape(annotatedFrame, 'FilledCircle', ...
[sortedPts, repmat(15, size(sortedPts,1), 1)], 'Color', 'yellow', 'Opacity', 1);

if size(sortedPts, 1) >= 2
for i = 1 : size(sortedPts, 1) - 1
linePts = [sortedPts(i,1) sortedPts(i,2) sortedPts(i+1,1) sortedPts(i+1,2)];
annotatedFrame = insertShape(annotatedFrame, 'Line', linePts, ...
'LineWidth', 10, 'Color', 'cyan');
end
end

labels = {'Shoulder', 'Elbow', 'Wrist'};
for j = 1:min(size(sortedPts, 1), 3)

textPos = sortedPts(j, :) + [20, -30];
annotatedFrame = insertText(annotatedFrame, textPos, labels{j}, ...
'FontSize', 22, 'BoxColor', 'yellow', 'BoxOpacity', 0.7, 'TextColor', 'black');
end
end

imshow(annotatedFrame);
drawnow;
writeVideo(outputVideo, annotatedFrame);

if ~ishandle(hFig), break; end
end

close(outputVideo);
disp('Video saved.');
