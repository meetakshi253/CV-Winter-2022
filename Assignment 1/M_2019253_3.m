MinEnclosingCircle("q3/shahar_walk.avi");

function MinEnclosingCircle(video_path)
    [p, f, ~] = fileparts(video_path);
    video_obj = VideoReader(video_path);
    video = read(video_obj);
    video_annotated = VideoWriter(strcat(p, "/", f, "_mec"), "Uncompressed AVI");
    video_annotated.FrameRate = video_obj.FrameRate;
    nframes = video_obj.NumFrames;
    video_frames = cell(nframes, 1);
    video_frames_annotated = cell(nframes, 1);

    for ii = 1:nframes   %extract all frames
        frame = video(:,:,:,ii);
        video_frames{ii} = double(frame);
    end

    video_median = double(median(video, 4));
    open(video_annotated);

    for ii = 1:nframes
        frame_fg = mean(abs(video_frames{ii}-video_median), 3); %mean of the 3 channels
        frame_fg = frame_fg/max(frame_fg(:)); %normalize
        frame_bin = imbinarize(frame_fg, graythresh(frame_fg));
        frame_blob_measurements = regionprops(frame_bin, 'BoundingBox');
        frame_blob_bound = frame_blob_measurements.BoundingBox;
        centre_x = double(frame_blob_bound(1) + frame_blob_bound(3)/2);
        centre_y = double(frame_blob_bound(2) + frame_blob_bound(4)/2);
        radius = double(max(frame_blob_bound(3), frame_blob_bound(4))/2);
        frame_annotated = insertShape(uint8(video_frames{ii}),"circle",[centre_x, centre_y, radius],"LineWidth",1, 'Color','red');
        video_frames_annotated{ii} = uint8(frame_annotated);
        writeVideo(video_annotated,uint8(frame_annotated));
    end

    close(video_annotated);
end