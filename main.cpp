#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "messenger.h"
#include "mstreamimageprovider.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("George Galt");
    app.setOrganizationDomain("georgegalt.com");
    app.setApplicationName("mStreamClient");

    QQmlApplicationEngine engine;
    Messenger *msg = new Messenger();
    qmlRegisterType<Messenger>("com.georgegalt.messenger", 1, 0, "Messenger");

    AsyncImageProvider *img = msg->getImageProvider();
    engine.addImageProvider("ablumimage",img);


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);


    return app.exec();
}
