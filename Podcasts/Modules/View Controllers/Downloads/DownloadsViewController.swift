//
//  DownloadsController.swift
//  Podcasts
//
//  Created by Eugene Karambirov on 21/09/2018.
//  Copyright © 2018 Eugene Karambirov. All rights reserved.
//

import UIKit

final class DownloadsViewController: UITableViewController {

    // MARK: - Properties
    fileprivate let viewModel: DownloadsViewModel

    // MARK: - View Controller's life cycle
    init(viewModel: DownloadsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchDownloads { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .downloadProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: .downloadComplete, object: nil)
    }

}

// MARK: - TableView
extension DownloadsViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Sizes.cellHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        launchEpisodePlayer(for: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.deleteEpisode(for: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - Setup
extension DownloadsViewController {

    fileprivate func initialSetup() {
        setupTableView()
        setupObservers()
    }

    fileprivate func launchEpisodePlayer(for indexPath: IndexPath) {
        let episode = viewModel.episode(for: indexPath)
        if episode.fileUrl != nil {
//            UIApplication.mainTabBarController?.maximizePlayerDetails(for: episode,
//                                                                      playlistEpisodes: viewModel.episodes)
        } else {
            askPermissonForPlayUsingStreaming(for: episode)
        }
    }

    fileprivate func askPermissonForPlayUsingStreaming(for episode: Episode) {
        let alertController = UIAlertController(title: "File URL not found",
                                                message: "Cannot find local file, play using stream URL instead",
                                                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//            UIApplication.mainTabBarController?.maximizePlayerDetails(for: episode,
//                                                                      playlistEpisodes: self.viewModel.episodes)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    private func setupTableView() {
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.typeName)
        tableView.dataSource = viewModel.dataSource
        tableView.tableFooterView = UIView()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress),
                                               name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewModel.handleDownloadComplete),
                                               name: .downloadComplete, object: nil)
    }

    @objc
    private func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }

        print(progress, title)

        guard let index = viewModel.episodes.firstIndex(where: { $0.title == title }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.isHidden = false

        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }

}

private extension DownloadsViewController {

    enum Sizes {
        static let cellHeight: CGFloat = 134
    }

}
