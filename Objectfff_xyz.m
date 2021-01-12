clear all;close all;clc 
     %helpes to get the intrinsic of the depth camera
    cfg = realsense.config();
    cfg.enable_stream(realsense.stream.depth);
    pipe = realsense.pipeline();
    profile = pipe.start(cfg);
    depth_stream = profile.get_stream(realsense.stream.depth);
    depth_stream = depth_stream.as('video_stream_profile');
    intrinsics1 = depth_stream.get_intrinsics();

pipe = realsense.pipeline();
profile = pipe.start();

disp('Initilization Complete')
% z distance inside camera
z = 0.0042; % m
i = 0;

% conversion between in/pixel
conv = 7.5 / 303.27;




figure('units','normalized','outerposition',[0 0 1 1])

while i <= 1000
    
    if i < 15
        fs = pipe.wait_for_frames();
        i;
        i = i + 1;
    else
        fs = pipe.wait_for_frames();
        color = fs.get_color_frame();
        data = color.get_data();
        img = permute(reshape(data',[3,color.get_width(),color.get_height()]),[3 2 1]);
        
        %Display the image
        subplot(1,2,1)
        imshow(img)
%         d=imdistline;
        [centers,radii] = imfindcircles(img,[35 55],'ObjectPolarity','dark','Sensitivity',0.92,'Method','twostage');
        h = viscircles(centers,radii);
        title(['Data at ',num2str(i),' frames'])

        subplot(1,2,2)

        depth = fs.get_depth_frame();

        centers = round(centers);
        % if there is a center, and its dist doees not equal zero, plot it
        if isempty(centers)

        elseif depth.get_distance(centers(1,:),centers(2,:)) ~= 0

            PixDist = depth.get_distance(centers(1),centers(2));
            x=(round(centers(1))-intrinsics1.ppx)/intrinsics1.fx;
            y=(round(centers(2))-intrinsics1.ppy)/intrinsics1.fy;
            X=PixDist*x;
            Y=PixDist*y;
            Z = PixDist;
            
            fprintf('X = %2.2f \t Y = %2.2f \t Z = %2.2f\n',X,Y,Z)
            plot3(X,Y,Z,'r.','MarkerSize',30)
            grid on
            axis([-5 5 -5 5 10 20]);
            title('Realtime Spatial Coordinates of the Ball')
            xlabel("X")
            ylabel("Y")
            zlabel("Z")
            drawnow
        end
        i = i + 1;
    end
end
