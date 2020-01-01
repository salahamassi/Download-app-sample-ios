//
//  DownloadItemCell.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//


import UIKit
import SDWebImage

class DownloadItemCell: UITableViewCell {
    
    var download: Download?{
        didSet{
            renderDownload()
        }
    }
    
    let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let fileTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.setBorder(cornerRadius: 2, borderColor: .clear, borderWidth: 0)
        progressView.tintColor = .red
        progressView.trackTintColor = .lightGray
        return progressView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(thumbImageView)
        addSubview(fileTypeLabel)
        addSubview(sizeLabel)
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(progressView)

        thumbImageView.anchor(leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0), size: CGSize(width: 82, height: 82))
        thumbImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        fileTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        fileTypeLabel.centerYAnchor.constraint(equalTo: thumbImageView.centerYAnchor).isActive = true
        fileTypeLabel.centerXAnchor.constraint(equalTo: thumbImageView.centerXAnchor).isActive = true
        
        
        sizeLabel.anchor(top: titleLabel.topAnchor,leading: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        
        titleLabel.anchor(top: thumbImageView.topAnchor, leading: thumbImageView.trailingAnchor, trailing: sizeLabel.leadingAnchor, padding: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16))
        
        progressView.anchor(trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 8), size: .init(width: 90, height: 5))
        progressView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func renderDownload(){
        guard let download = download else { return }
        titleLabel.text = download.title
        timeLabel.text = download.createdAt?.getElapsedInterval()
        
        if let image = download.thumb{
            if download.type == Constants.DownloadType.image{
                thumbImageView.sd_setImage(with: download.localFile?.localURL, placeholderImage: UIImage(named: "default-thumbnail"))
            }else if image.starts(with: "http") || image.starts(with: "https"){
                thumbImageView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "default-thumbnail"))
            }else{
                thumbImageView.sd_setImage(with: image.localURL, placeholderImage: UIImage(named: "default-thumbnail"))
            }
        }else{
            if let localURL = download.localFile?.localURL {
                self.sizeLabel.text = localURL.sizeForLocalFilePath().sizeToString()
                let thumbImage = localURL.getThumb()
                thumbImageView.image = thumbImage
                if localURL.pathExtension.noIcon{
                    fileTypeLabel.isHidden = false
                    fileTypeLabel.text = localURL.pathExtension
                }else{
                    fileTypeLabel.text = ""
                    fileTypeLabel.isHidden = true
                }
            }else {
                thumbImageView.image = #imageLiteral(resourceName: "document")
            }
        }
        if download.progress < 1.0 && download.progress > 0.0 && download.localFile == nil{
            sizeLabel.text = "\(round(download.progress * 100.0))%"
            progressView.isHidden = false
            progressView.setProgress(Float(download.progress), animated: true)
        }else if let path = download.localFile{
            progressView.isHidden = true
            self.sizeLabel.text = (path.localURL?.sizeForLocalFilePath() ?? 0).sizeToString()
        }else if download.progress == 0 {
            sizeLabel.text = "In Queue"
            progressView.setProgress(0.0, animated: true)
            progressView.isHidden = false
        }else{
            progressView.isHidden = true
            sizeLabel.text = ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

