#QRcodeSweep
通过iOS原生框架AVFoundation实现的扫描二维码的功能。



#pragma mark - AVCaptureMetadataOutputObjectsDelegate
	- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
	{
    //判断是否有数据
    
    //判断回传的数据类型
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"执行一次");
            self.str = [metadataObj stringValue];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
            
            [self performSelectorOnMainThread:@selector(backPopGetQRcode) withObject:nil waitUntilDone:NO];
        	}
    	}
	}