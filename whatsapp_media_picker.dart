import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tutorial_flutter/media_services.dart';

class WhatsappMediaPicker extends StatefulWidget {
  const WhatsappMediaPicker({super.key});

  @override
  State<WhatsappMediaPicker> createState() => _WhatsappMediaPickerState();
}

class _WhatsappMediaPickerState extends State<WhatsappMediaPicker> {
  List<AssetPathEntity> albumList = [];

  @override
  void initState() {
    MediaServices().loadAlbums(RequestType.common).then(
      (value) {
        setState(() {
          albumList = value;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff111b21),
        appBar: AppBar(
          backgroundColor: const Color(0xff202c33),
          title: const Text("WhatsApp Media Picker"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(4),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: albumList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              AssetPathEntity album = albumList[index];
              return AlbumWidget(album);
            },
          ),
        ),
      ),
    );
  }
}

class AlbumWidget extends StatefulWidget {
  final AssetPathEntity album;
  const AlbumWidget(this.album, {super.key});

  @override
  State<AlbumWidget> createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget> {
  List<AssetEntity> assetList = [];
  AssetEntity? recentAsset;

  void getRecentAsset() async {
    await MediaServices().loadAssets(widget.album).then(
      (value) {
        setState(() {
          assetList = value;
          recentAsset = value[0];
        });
      },
    );
  }

  @override
  void initState() {
    getRecentAsset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return recentAsset == null
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AlbumAssets(widget.album.name, assetList);
                  },
                ),
              );
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: AssetEntityImage(
                    recentAsset!,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(250),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color.fromARGB(202, 30, 39, 44),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // ignore: deprecated_member_use
                            widget.album.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            // ignore: deprecated_member_use
                            "${widget.album.assetCount}",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class AlbumAssets extends StatefulWidget {
  final String albumName;
  final List<AssetEntity> assetList;
  const AlbumAssets(this.albumName, this.assetList, {super.key});

  @override
  State<AlbumAssets> createState() => _AlbumAssetsState();
}

class _AlbumAssetsState extends State<AlbumAssets> {
  List<AssetEntity> selectedAssetList = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff111b21),
        appBar: AppBar(
          backgroundColor: const Color(0xff202c33),
          title: selectedAssetList.isEmpty
              ? Text(widget.albumName)
              : Text("${selectedAssetList.length} Selected"),
        ),
        body: widget.assetList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(3),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.assetList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                  ),
                  itemBuilder: (context, index) {
                    AssetEntity assetEntity = widget.assetList[index];
                    return assetWidget(assetEntity);
                  },
                ),
              ),
        bottomNavigationBar: selectedAssetList.isEmpty
            ? const SizedBox.shrink()
            : Container(
                color: const Color(0xff202c33),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 4,
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Flexible(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedAssetList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.5,
                                ),
                                child: SizedBox(
                                  width: 50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: AssetEntityImage(
                                      selectedAssetList[index],
                                      isOriginal: false,
                                      thumbnailSize:
                                          const ThumbnailSize.square(250),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff00a884),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

    void selectAsset({
    required AssetEntity assetEntity,
  }) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    }
  }

  Widget assetWidget(AssetEntity assetEntity) => GestureDetector(
        onTap: () {
          selectAsset(assetEntity: assetEntity);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetEntityImage(
                assetEntity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
            if (assetEntity.type == AssetType.video)
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Iconsax.video5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (selectedAssetList.contains(assetEntity) == true)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedAssetList.contains(assetEntity) == true
                        ? Colors.black26
                        : Colors.transparent,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
