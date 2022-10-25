#include "UserMobileSurface.h"
#include "dprintf.h"
#include <string>
#include <map>

static std::map<int, UserMobileSurface *> g_surfaces;

// Users must implement createMobileSurface() to return a pointer to their derived MobileSurface
// Only one surface is created is created in the sandbox apps.
MobileSurface *createMobileSurface(int guiSurfaceId)
{
    if (g_surfaces.count(guiSurfaceId) == 0)
    {
        auto surface = new UserMobileSurface();
        g_surfaces.insert(std::make_pair(guiSurfaceId, surface));
        return surface;
    }
    return g_surfaces[guiSurfaceId];
}

void destoryMobileSurface(int guiSurfaceId) {
    if (g_surfaces.count(guiSurfaceId) != 0) {
        MobileSurface *mobileSurface = g_surfaces[guiSurfaceId];
        g_surfaces.erase(guiSurfaceId);
        delete mobileSurface;
        mobileSurface = nullptr;
    }
}

UserMobileSurface::UserMobileSurface()
:  displayResourceMonitor(false), currentRenderingMode(HPS::Rendering::Mode::Default), frameRateEnabled(false)
{
}

UserMobileSurface::~UserMobileSurface()
{
}

bool UserMobileSurface::bind(void *window)
{
    bool status = MobileSurface::bind(window);
    // Perform surface init code here.
    return status;
}

void UserMobileSurface::release(int flags)
{
    if ((flags & SCREEN_ROTATING) == 0)
    {
        HPS::Canvas canvas = GetCanvas();
        HPS::Layout layout = canvas.GetAttachedLayout();
        if (layout.Type() != HPS::Type::None)
        {
            canvas.DetachLayout();
            if (layout.GetLayerCount() > 0)
            {
                HPS::View view = layout.GetFrontView();
                if (view.Type() != HPS::Type::None)
                {
                    HPS::Model model = view.GetAttachedModel();
                    if (model.Type() != HPS::Type::None)
                        model.Delete();
                    view.Delete();
                }
            }
            layout.Delete();
        }

#ifdef USING_EXCHANGE
        if (activeCADModel.Type() != HPS::Type::None)
            activeCADModel.Delete();
#endif
    }

    MobileSurface::release(flags);
}

void UserMobileSurface::singleTap(int x, int y)
{
    MobileSurface::singleTap(x, y);
    //dprintf("Single tap: %d %d\n", x, y);
}

void UserMobileSurface::doubleTap(int x, int y, HPS::TouchID id)
{
    MobileSurface::doubleTap(x, y, id);
    InjectTouchEvent(HPS::TouchEvent::Action::TouchDown, 1, &x, &y, &id, 2);
}

void UserMobileSurface::SetupSceneDefaults()
{
    HPS::View               view = GetCanvas().GetFrontView();
    view.GetOperatorControl().Push(new HPS::ZoomFitTouchOperator()).Push(new HPS::PanOrbitZoomOperator());
}

void UserMobileSurface::SetMainDistantLight(HPS::Vector const & lightDirection)
{
    HPS::DistantLightKit    light;
    light.SetDirection(lightDirection);
    light.SetCameraRelative(true);
    SetMainDistantLight(light);
}

void UserMobileSurface::SetMainDistantLight(HPS::DistantLightKit const & light)
{
    // Delete previous light before inserting new one
    if (mainDistantLight.Type() != HPS::Type::None)
        mainDistantLight.Delete();
    mainDistantLight = GetCanvas().GetFrontView().GetSegmentKey().InsertDistantLight(light);
}

bool UserMobileSurface::importPointCloudFile(const char * filename, HPS::Model const & model)
{
    HPS::IOResult           status = HPS::IOResult::Failure;

    HPS::PointCloud::ImportNotifier notifier;
    try
    {
        // Specify the model segment as the segment to import to
        HPS::PointCloud::ImportOptionsKit           ioOpts;
        ioOpts.SetSegment(model.GetSegmentKey());
        // Initiate import and wait.  Import is done on a separate thread.
        notifier = HPS::PointCloud::File::Import(filename, ioOpts);
        
        notifier.Wait();

        status = notifier.Status();
    }
    catch (HPS::IOException const & ex)
    {
        status = ex.result;
    }

    if (status != HPS::IOResult::Success)
        return false;

    return true;
}

bool UserMobileSurface::importHSFFile(const char * filename, HPS::Model const & model, HPS::Stream::ImportResultsKit & importResults)
{
    HPS::IOResult           status = HPS::IOResult::Failure;
    HPS::Stream::ImportNotifier     notifier;

    // HPS::Stream::File::Import can throw HPS::Stream::IOException
    try
    {
        // Specify the model segment as the segment to import to
        HPS::Stream::ImportOptionsKit           ioOpts;
        ioOpts.SetSegment(model.GetSegmentKey());
        ioOpts.SetAlternateRoot(model.GetLibraryKey());
        ioOpts.SetPortfolio(model.GetPortfolioKey());

        // Initiate import and wait.  Import is done on a separate thread.
        notifier = HPS::Stream::File::Import(filename, ioOpts);
        notifier.Wait();

        status = notifier.Status();
    }
    catch (HPS::IOException const & ex)
    {
        status = ex.result;
    }

    if (status != HPS::IOResult::Success)
        return false;

    importResults = notifier.GetResults();
    return true;
}

bool UserMobileSurface::importSTLFile(const char * filename, HPS::Model const & model)
{
    HPS::IOResult           status = HPS::IOResult::Failure;

    HPS::STL::ImportNotifier notifier;
    // HPS::Stream::File::Import can throw HPS::Stream::IOException
    try
    {
        // Specify the model segment as the segment to import to
        HPS::STL::ImportOptionsKit          ioOpts;
        ioOpts.SetSegment(model.GetSegmentKey());

        // Initiate import and wait.  Import is done on a separate thread.
        notifier = HPS::STL::File::Import(filename, ioOpts);
        notifier.Wait();

        status = notifier.Status();
    }
    catch (HPS::IOException const & ex)
    {
        status = ex.result;
    }

    if (status != HPS::IOResult::Success)
        return false;

    return true;
}

bool UserMobileSurface::importOBJFile(const char * filename, HPS::Model const & model)
{
    HPS::IOResult           status = HPS::IOResult::Failure;

    HPS::OBJ::ImportNotifier notifier;
    // HPS::Stream::File::Import can throw HPS::Stream::IOException
    try
    {
        // Specify the model segment as the segment to import to
        HPS::OBJ::ImportOptionsKit          ioOpts;
        ioOpts.SetSegment(model.GetSegmentKey());
        ioOpts.SetPortfolio(model.GetPortfolioKey());

        // Initiate import and wait.  Import is done on a separate thread.
        notifier = HPS::OBJ::File::Import(filename, ioOpts);
        notifier.Wait();

        status = notifier.Status();
    }
    catch (HPS::IOException const & ex)
    {
        status = ex.result;
    }

    if (status != HPS::IOResult::Success)
        return false;

    return true;
}

#ifdef USING_EXCHANGE

bool UserMobileSurface::importExchangeFile(const char * filename, HPS::Exchange::ImportOptionsKit ioOpts)
{
    HPS::IOResult           status = HPS::IOResult::Failure;

    HPS::Exchange::ImportNotifier notifier;
    // HPS::Stream::File::Import can throw HPS::Stream::IOException
    try
    {
        // Specify the import info
        ioOpts.SetBRepMode(HPS::Exchange::BRepMode::BRepAndTessellation);
        ioOpts.SetTessellationCleanup(true);
        ioOpts.SetPMIFlipping(true);
        ioOpts.SetPMISubstitutionFont("Myriad CAD Regular");

        // Initiate import and wait.  Import is done on a separate thread.
        notifier = HPS::Exchange::File::Import(filename, ioOpts);
        notifier.Wait();

        status = notifier.Status();

        if (status == HPS::IOResult::Success)
        {
            activeCADModel = notifier.GetCADModel();
            HPS::View view = activeCADModel.ActivateDefaultCapture();
            GetCanvas().AttachViewAsLayout(view);
        }
    }
    catch (HPS::IOException const & ex)
    {
        status = ex.result;
    }

    return status == HPS::IOResult::Success;
}
#endif

bool UserMobileSurface::loadFile(const char* fileName)
{
    std::string fileNameStr(fileName);
    size_t loc = fileNameStr.find_last_of(".");

    if (loc == std::string::npos)
        return false;

    std::string extension = fileNameStr.substr(loc + 1, fileNameStr.size() - (loc + 1));
    std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);


    bool fit_world = false;
    if (extension == "hsf")
    {
        HPS::Stream::ImportResultsKit stream_results;
        HPS::Model model = HPS::Factory::CreateModel();
        if (!importHSFFile(fileName, model, stream_results))
        {
            model.Delete();
            return false;
        }

        HPS::View view = HPS::Factory::CreateView();
        view.AttachModel(model);
        GetCanvas().AttachViewAsLayout(view);

        HPS::CameraKit defaultCamera;
        if (stream_results.ShowDefaultCamera(defaultCamera))
            view.GetSegmentKey().SetCamera(defaultCamera);
        else
            fit_world = true;
    }
    else if (extension == "stl")
    {
        HPS::Model model = HPS::Factory::CreateModel();
        if (!importSTLFile(fileName, model))
        {
            model.Delete();
            return false;
        }

        HPS::View view = HPS::Factory::CreateView();
        view.AttachModel(model);
        GetCanvas().AttachViewAsLayout(view);
        fit_world = true;
    }
    else if (extension == "obj")
    {
        HPS::Model model = HPS::Factory::CreateModel();
        if (!importOBJFile(fileName, model))
        {
            model.Delete();
            return false;
        }

        HPS::View view = HPS::Factory::CreateView();
        view.AttachModel(model);
        GetCanvas().AttachViewAsLayout(view);
        fit_world = true;
    }
    else if (extension == "ptx" || extension == "pts" || extension == "xyz")
    {
        HPS::Model model = HPS::Factory::CreateModel();
        if (!importPointCloudFile(fileName, model))
        {
            model.Delete();
            return false;
        }

        HPS::View view = HPS::Factory::CreateView();
        view.AttachModel(model);
        GetCanvas().AttachViewAsLayout(view);
        fit_world = true;
    }
#ifdef USING_EXCHANGE
    else if (extension == "pdf")
    {
        HPS::Exchange::ImportOptionsKit         ioOpts;
        ioOpts.SetPDF3DStreamIndex(0);

        if (!importExchangeFile(fileName, ioOpts))
            return false;
    }
    else if (extension == "prc" || extension == "u3d" || extension == "jt" || extension == "igs"
    		|| extension == "iges" || extension == "stp" || extension == "step" || extension == "ifc"
    		|| extension == "ifczip" || extension == "x_b" || extension == "x_t" || extension == "x_mt"
#   if TARGET_OS_ANDROID == 1
	 		|| extension == "dwg" || extension == "dxf"
#   endif
			|| extension == "xmt_txt")
    {
        if (!importExchangeFile(fileName))
            return false;
    }
#endif
    else
        
        return false;

    HPS::View view = GetCanvas().GetFrontView();
    HPS::Model model = view.GetAttachedModel();

    // Enable static model for better performance
    model.GetSegmentKey().GetPerformanceControl().SetStaticModel(HPS::Performance::StaticModel::Attribute);

    if (fit_world)
        view.FitWorld();

    // setup scene defaults
    SetupSceneDefaults();

    // Add a distant light
    SetMainDistantLight();

    GetCanvas().UpdateWithNotifier().Wait();

    return true;
}
void UserMobileSurface::segControlValueChanged(long index)
{
    if (index == 2) {
        addcuttingSection();
    } else {
        removecuttingSection();
    }
}

void UserMobileSurface::removecuttingSection()
{
    if (cuttingOperatorPtr) {
        GetCanvas().GetFrontView().GetOperatorControl().Pop(HPS::Operator::Priority::High);
        GetCanvas().GetFrontView().Update();
        cuttingOperatorPtr = nullptr;
    }
}

void UserMobileSurface::addcuttingSection()
{
    if (cuttingOperatorPtr == nullptr) {
        cuttingOperatorPtr =  new HPS::CuttingSectionOperator();
        HPS::MaterialMappingKit mappingKit = cuttingOperatorPtr->GetPlaneMaterial();
        mappingKit.SetCutFaceAlpha(1);
        mappingKit.SetCutEdgeColor(HPS::RGBAColor(0, 0, 0, 0));
        cuttingOperatorPtr->SetPlaneMaterial(mappingKit);
        GetCanvas().GetFrontView().GetOperatorControl().Push(cuttingOperatorPtr, HPS::Operator::Priority::High);
    }
}
void UserMobileSurface::setOperatorOrbit()
{
    GetCanvas().GetFrontView().GetOperatorControl().Pop();
    GetCanvas().GetFrontView().GetOperatorControl().Push(new HPS::PanOrbitZoomOperator());
}

void UserMobileSurface::setOperatorZoomArea()
{
    GetCanvas().GetFrontView().GetOperatorControl().Pop();
    GetCanvas().GetFrontView().GetOperatorControl().Push(new HPS::ZoomBoxOperator());
}

void UserMobileSurface::setOperatorFly()
{
    GetCanvas().GetFrontView().GetOperatorControl().Pop();
    GetCanvas().GetFrontView().GetOperatorControl().Push(new HPS::FlyOperator());
}

void UserMobileSurface::setOperatorSelectPoint()
{
    GetCanvas().GetFrontView().GetOperatorControl().Pop();
    GetCanvas().GetFrontView().GetOperatorControl().Push(new HPS::HighlightOperator());
}

void UserMobileSurface::setOperatorSelectArea()
{
    GetCanvas().GetFrontView().GetOperatorControl().Pop();
    GetCanvas().GetFrontView().GetOperatorControl().Push(new HPS::HighlightAreaOperator());
}

void UserMobileSurface::onModeSimpleShadow(bool enable)
{
    if (!isValid())
        return;

    if (enable == true)
    {
        // Set simple shadow options
        const float                 opacity = 0.3f;
        const unsigned int          resolution = 512;
        const unsigned int          blurring = 20;

        // Set opacity in simple shadow color
        HPS::RGBAColor              color(0.4f, 0.4f, 0.4f, opacity);
        if (GetCanvas().GetFrontView().GetSegmentKey().GetVisualEffectsControl().ShowSimpleShadowColor(color))
            color.alpha = opacity;

        GetCanvas().GetFrontView().GetSegmentKey().GetVisualEffectsControl()
        .SetSimpleShadow(enable, resolution, blurring)
        .SetSimpleShadowColor(color);
    }

    GetCanvas().GetFrontView().SetSimpleShadow(enable);
    GetCanvas().Update();
}

void UserMobileSurface::onModeSmooth()
{
    if (!isValid())
        return;

    // Toggle Phong on/off
    if (currentRenderingMode == HPS::Rendering::Mode::Phong)
        currentRenderingMode = HPS::Rendering::Mode::Default;
    else
        currentRenderingMode = HPS::Rendering::Mode::Phong;

    GetCanvas().GetFrontView().SetRenderingMode(currentRenderingMode);
    GetCanvas().Update();
}

void UserMobileSurface::onModeHiddenLine()
{
    if (!isValid())
        return;

    // Toggle hidden line
    if (currentRenderingMode == HPS::Rendering::Mode::FastHiddenLine)
        currentRenderingMode = HPS::Rendering::Mode::Default;
    else
    {
        currentRenderingMode = HPS::Rendering::Mode::FastHiddenLine;

        // fixed framerate is not compatible with hidden line
        if (frameRateEnabled)
        {
            GetCanvas().SetFrameRate(0);
            frameRateEnabled = false;
        }
    }

    GetCanvas().GetFrontView().SetRenderingMode(currentRenderingMode);
    GetCanvas().Update();
}

void UserMobileSurface::onModeFrameRate()
{
    if (!isValid())
        return;

    const float                 frameRate = 20.0f;

    // Toggle frame rate and set.  Note that 0 disables frame rate.
    frameRateEnabled = !frameRateEnabled;

    if (frameRateEnabled)
    {
        GetCanvas().SetFrameRate(frameRate);

        // fixed framerate is not compatible with hidden line
        if (currentRenderingMode == HPS::Rendering::Mode::FastHiddenLine)
        {
            currentRenderingMode = HPS::Rendering::Mode::Default;
            GetCanvas().GetFrontView().SetRenderingMode(currentRenderingMode);
        }
    }
    else
        GetCanvas().SetFrameRate(0);

    GetCanvas().Update();
}

void UserMobileSurface::onUserCode1()
{
    testPerformance();
}

void UserMobileSurface::onUserCode2()
{
    // TODO: Add your command handler code here
    dprintf("user code 2\n");
}

void UserMobileSurface::onUserCode3()
{
    // TODO: Add your command handler code here
    dprintf("user code 3\n");
}
void UserMobileSurface::insertcuttingSectonPlane(int index)
{
    if (cuttingOperatorPtr == nullptr) {
        addcuttingSection();
    }
    HPS::CameraKit cameraKit;
    GetCanvas().GetFrontView().GetSegmentKey().ShowCamera(cameraKit);
    HPS::Point target;
    cameraKit.ShowTarget(target);
    
    HPS::Plane plane;
    switch (index) {
        case 0:
        {
            float x = -fabs(target.x);
            plane = HPS::Plane(1, 0, 0, x);
        }
            break;
        case 1:
        {
            float y = -fabs(target.y);
            plane = HPS::Plane(0, 1, 0, y);
        }
            break;
        case 2:
        {
            float z = -fabs(target.z);
            plane = HPS::Plane(0, 0, 1, z);
        }
            break;
        default:
            break;
    }
    HPS::PlaneArray         planeArray;
    planeArray.push_back(plane);
    cuttingOperatorPtr->SetPlanes(planeArray);
    GetCanvas().Update();
}

void UserMobileSurface::onUserCode4()
{
    // TODO: Add your command handler code here
    dprintf("user code 4\n");
}
