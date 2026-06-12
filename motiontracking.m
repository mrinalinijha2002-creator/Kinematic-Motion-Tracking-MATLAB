inputFile = 'handvideo.mp4';
videoSource = VideoReader(inputFile);
outputFile = 'C:\Users\mrina\OneDrive\Desktop\Arm_Tracking_Fixed_Final.mp4';

outputVideo = VideoWriter(outputFile, 'MPEG-4');
outputVideo.FrameRate = videoSource.FrameRate;
open(outputVideo);

hFig = figure('Name', 'Arm Tracking');

while hasFrame(videoSource)
    frame = readFrame(videoSource);

    % Step 1: Red color channel isolation
    redIntensity = imsubtract(frame(:,:,1), rgb2gray(frame));

    % Step 2: Thresholding to create a binary mask
    binaryMask = redIntensity > 50;

    % Step 3: Morphological closing to fill gaps in the shapes
    binaryMask = imclose(binaryMask, strel('disk', 15));

    % Step 4: Remove small background noise blobs
    binaryMask = bwareaopen(binaryMask, 500);

    % Step 5: Calculate Centroids of the tracked points
    stats = regionprops(binaryMask, 'Centroid');

    annotatedFrame = frame;

    if ~isempty(stats)
        allPoints = cat(1, stats.Centroid);

        % Ensure we have at least 3 detected points to track structural joints
        if size(allPoints, 1) >= 3
            allPoints = allPoints(1:3, :);

            % 1. Identify Shoulder: Mathematically highest point in frame (minimum Y value)
            [~, shoulderIdx] = min(allPoints(:, 2));
            shoulderPt = allPoints(shoulderIdx, :);

            % Filter out the shoulder point to isolate remaining joints
            remainingPts = allPoints;
            remainingPts(shoulderIdx, :) = [];

            % 2. Identify Elbow: Calculated as the closest point to the Shoulder using Euclidean Distance
            distToShoulder = sqrt((remainingPts(:,1) - shoulderPt(1)).^2 + (remainingPts(:,2) - shoulderPt(2)).^2);
            [~, elbowIdx] = min(distToShoulder);
            elbowPt = remainingPts(elbowIdx, :);

            % 3. Identify Wrist: The remaining structural point must be the wrist
            remainingPts(elbowIdx, :) = [];
            wristPt = remainingPts(1, :);

            % Reassemble the matrix in correct structural order
            sortedPts = [shoulderPt; elbowPt; wristPt];
        else
            % Fallback sorting mechanism if fewer than 3 keypoints are detected
            sortedPts = sortrows(allPoints, 1);
        end

        % Draw Tracking Circles on detected joints
        annotatedFrame = insertShape(annotatedFrame, 'FilledCircle', ...
            [sortedPts, repmat(15, size(sortedPts,1), 1)], 'Color', 'yellow', 'Opacity', 1);

        % Connect the joints with Tracking Linkage Lines
        if size(sortedPts, 1) >= 2
            for i = 1 : size(sortedPts, 1) - 1
                linePts = [sortedPts(i,1) sortedPts(i,2) sortedPts(i+1,1) sortedPts(i+1,2)];
                annotatedFrame = insertShape(annotatedFrame, 'Line', linePts, ...
                    'LineWidth', 10, 'Color', 'cyan');
            end
        end

        % Apply text labels to the mapped coordinates
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
