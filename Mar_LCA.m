baseFileName = 'Mar27_Heart';
fileExtension = '_left.nii';

% Set the range of file indices you want to open
startIndex = 2;
endIndex = 5;  % Adjust this based on the number of files you have

% Loop through the file indices
for index = startIndex:endIndex
    % Construct the full file name
    fullFileName = [baseFileName, num2str(index), fileExtension];
        %open file
        V = niftiread(fullFileName);  % Use 'r' for reading, adjust as needed
        skel = imbinarize(V);
    skel = bwskel(skel);
    %volshow(skel);

    save skel

    load skel
    
    w = size(skel,1);
    l = size(skel,2);
    h = size(skel,3);
    
    % initial step: condense, convert to voxels and back, detect cells
    [~,node,link] = Skel2Graph3D(skel,20);
    
    % total length of network
    wl = sum(cellfun('length',{node.links}));
    
    skel2 = Graph2Skel3D(node,link,w,l,h);
    [~,node2,link2] = Skel2Graph3D(skel2,0);
    
    % calculate new total length of network
    wl_new = sum(cellfun('length',{node2.links}));
    
    % iterate the same steps until network length changed by less than 0.5%
    while(wl_new~=wl)
    
        wl = wl_new;   
        
         skel2 = Graph2Skel3D(node2,link2,w,l,h);
         [A2,node2,link2] = Skel2Graph3D(skel2,0);
    
         wl_new = sum(cellfun('length',{node2.links}));
    
    end;
    
    % display result
    figure();
    hold on;
    for i=1:length(node2)
        x1 = node2(i).comx;
        y1 = node2(i).comy;
        z1 = node2(i).comz;
        
        if(node2(i).ep==1)
            ncol = 'c';
        else
            ncol = 'y';
        end;
        
        for j=1:length(node2(i).links)    % draw all connections of each node
            if(node2(node2(i).conn(j)).ep==1)
                col='k'; % branches are black
            else
                col='r'; % links are red
            end;
            if(node2(i).ep==1)
                col='k';
            end;
    
            
            % draw edges as lines using voxel positions
            for k=1:length(link2(node2(i).links(j)).point)-1            
                [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k));
                [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1));
                line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
            end;
        end;
        
        % draw all nodes as yellow circles
        plot3(y1,x1,z1,'o','Markersize',9,...
            'MarkerFaceColor',ncol,...
            'Color','k');
    end;
    axis image;axis off;
    set(gcf,'Color','white');
    drawnow;
    view(-17,46);
    count = nnz(arrayfun(@(node2) all(node2.ep == 0), node2));
    disp(count);

end